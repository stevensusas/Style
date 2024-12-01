from pymongo import MongoClient
from bson import ObjectId

# MongoDB connection (using the same connection string from your main.py)
client = MongoClient(
    "mongodb+srv://default:12345678abc@style.wxs7m.mongodb.net/?retryWrites=true&w=majority&appName=Style"
)
db = client["default"]
users_collection = db["users"]
deals_collection = db["deals"]


def seed_database():
    # First, let's create some deals
    deals = [
        {"_id": str(ObjectId()), "description": "50% off at Nike Store"},
        {"_id": str(ObjectId()), "description": "Buy 1 Get 1 Free at Starbucks"},
        {"_id": str(ObjectId()), "description": "$20 off first Uber ride"},
        {"_id": str(ObjectId()), "description": "30% discount on Amazon Electronics"},
        {"_id": str(ObjectId()), "description": "Free delivery on FoodPanda"},
    ]

    # Insert deals
    deals_collection.insert_many(deals)
    print("Deals added successfully!")

    # Create some users with empty friends/deals lists
    users = [
        {
            "username": "john_doe",
            "password": "password123",
            "friends": [],
            "deals": [
                deals[0]["_id"],
                deals[1]["_id"],
            ],  # Adding first two deals to this user
        },
        {
            "username": "jane_smith",
            "password": "password456",
            "friends": [],
            "deals": [deals[2]["_id"]],  # Adding third deal to this user
        },
        {
            "username": "bob_wilson",
            "password": "password789",
            "friends": [],
            "deals": [],  # No deals for this user
        },
    ]

    # Insert users
    users_collection.insert_many(users)
    print("Users added successfully!")


if __name__ == "__main__":
    # Clear existing data (optional)
    users_collection.delete_many({})
    deals_collection.delete_many({})
    print("Existing data cleared!")

    # Seed the database
    seed_database()
    print("Database seeded successfully!")
