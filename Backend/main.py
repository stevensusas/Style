from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from pydantic import BaseModel
from fastapi import HTTPException
import random
from bson import ObjectId


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# MongoDB connection
client = MongoClient(
    "mongodb+srv://default:12345678abc@style.wxs7m.mongodb.net/?retryWrites=true&w=majority&appName=Style"
)
db = client["default"]  # Replace with your database name
users_collection = db["users"]
deals_collection = db["deals"]


# Basic Item model
class User(BaseModel):
    username: str
    password: str
    friends: list[str]
    deals: list[str]


class UserLogin(BaseModel):
    username: str
    password: str


class Deal(BaseModel):
    description: str


@app.post("/signup")
async def signup(user: User):
    """
    Register a new user

    Request Body:
        user (User): User object containing username, password, friends[], deals[]

    Returns:
        dict: Message confirming creation and user_id

    Raises:
        HTTPException (400): If username already exists
    """
    # Check if username or email already exists
    if users_collection.find_one({"$or": [{"username": user.username}]}):
        raise HTTPException(status_code=400, detail="Username already exists")

    # Create user document
    user_dict = user.dict()

    # Insert into database
    result = users_collection.insert_one(user_dict)

    return {"message": "User created successfully", "user_id": str(result.inserted_id)}


@app.post("/login")
async def login(user_credentials: UserLogin):
    """
    Authenticate user and return profile

    Request Body:
        user_credentials (UserLogin): Object containing username and password

    Returns:
        dict: User profile with username, friends list, and deals list

    Raises:
        HTTPException (401): If credentials are invalid
    """
    # Find user by username
    user = users_collection.find_one({"username": user_credentials.username})

    if not user:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    # Check password
    if user["password"] != user_credentials.password:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    # Convert ObjectId to string for JSON response
    user["_id"] = str(user["_id"])

    return {
        "message": "Login successful",
        "username": user["username"],
        "friends": user["friends"],
        "deals": user["deals"],
    }


@app.post("/users/{username}/deals/{deal_id}")
async def add_deal_to_user(username: str, deal_id: str):
    """
    Add an existing deal to user's collection

    Parameters:
        username (str): Target user's username
        deal_id (str): ID of deal to add

    Returns:
        dict: Confirmation message with username and deal_id

    Raises:
        HTTPException (404): If user or deal not found
        HTTPException (400): If deal already in user's list
    """
    # Find user
    user = users_collection.find_one({"username": username})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Check if deal exists
    deal = deals_collection.find_one({"_id": deal_id})
    if not deal:
        raise HTTPException(status_code=404, detail="Deal not found")

    # Check if deal is already in user's list
    if deal_id in user["deals"]:
        raise HTTPException(status_code=400, detail="Deal already added to user")

    # Add deal ID to user's deals list
    users_collection.update_one({"username": username}, {"$push": {"deals": deal_id}})

    return {
        "message": "Deal added to user successfully",
        "username": username,
        "deal_id": deal_id,
    }


@app.get("/deals/random")
async def get_random_deal():
    """
    Get a random deal from the deals collection

    Returns:
        dict: A random deal with its details

    Raises:
        HTTPException (404): If no deals are found
    """
    deals = list(deals_collection.find({}))
    if not deals:
        raise HTTPException(status_code=404, detail="No deals found")

    random_deal = random.choice(deals)
    random_deal["_id"] = str(random_deal["_id"])  # Convert ObjectId to string
    return random_deal

@app.get("/users/{username}/deals")
async def get_user_deals(username: str):
    """
    Get all deals in user's collection

    Parameters:
        username (str): Target user's username

    Returns:
        list: Array of deals in user's collection

    Raises:
        HTTPException (404): If user not found
    """
    # Find user
    user = users_collection.find_one({"username": username})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get user's deals
    user_deals = user.get("deals", [])

    # Fetch all deals that are in user's deals list
    deals = list(
        deals_collection.find(
            {"_id": {"$in": user_deals}}, {"_id": 1, "brand": 1, "description": 1}
        )
    )

    # Convert ObjectId to string for JSON response
    for deal in deals:
        deal["_id"] = str(deal["_id"])

    return deals

@app.get("/users/{username}/new-deals")
async def get_new_deals(username: str):
    """
    Get all deals not in user's collection

    Parameters:
        username (str): Target user's username

    Returns:
        list: Array of deals not in user's collection

    Raises:
        HTTPException (404): If user not found
    """
    # Find user
    user = users_collection.find_one({"username": username})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Get user's existing deals
    user_deals = user.get("deals", [])

    # Find all deals that are not in user's deals list
    new_deals = list(
        deals_collection.find(
            {"_id": {"$nin": user_deals}},
            {"_id": 1, "brand": 1, "description": 1},  # Include fields
        )
    )

    # Convert ObjectId to string for JSON response
    for deal in new_deals:
        deal["_id"] = str(deal["_id"])

    return new_deals

# Trade endpoint
@app.post("/trades/confirm")
async def confirm_trade(trade: Trade):
    from_user = users_collection.find_one({"username": trade.from_user})
    if not from_user:
        raise HTTPException(status_code=404, detail="From user not found")
    to_user = users_collection.find_one({"username": trade.to_user})
    if not to_user:
        raise HTTPException(status_code=404, detail="To user not found")

    try:
        from_deal_id = ObjectId(trade.from_deal_id)
        to_deal_id = ObjectId(trade.to_deal_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid deal IDs")

    if from_deal_id not in from_user.get("deals", []):
        raise HTTPException(status_code=400, detail="From user does not own the deal")
    if to_deal_id not in to_user.get("deals", []):
        raise HTTPException(status_code=400, detail="To user does not own the deal")

    # Perform the trade
    users_collection.update_one(
        {"username": trade.from_user},
        {"$pull": {"deals": from_deal_id}, "$push": {"deals": to_deal_id}},
    )
    users_collection.update_one(
        {"username": trade.to_user},
        {"$pull": {"deals": to_deal_id}, "$push": {"deals": from_deal_id}},
    )

    return {"message": "Trade completed successfully"}
