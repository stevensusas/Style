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
    deals = [
        {
            "_id": str(ObjectId()),
            "brand": "Zara",
            "description": "20% off on all dresses",
        },
        {
            "_id": str(ObjectId()),
            "brand": "H&M",
            "description": "Buy 2 get 1 free on T-shirts",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Uniqlo",
            "description": "15% off on winter collection",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Nike",
            "description": "30% off on sneakers",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Adidas",
            "description": "25% off on sportswear",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Gucci",
            "description": "Exclusive 40% off on handbags",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Louis Vuitton",
            "description": "50% off on selected items",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Prada",
            "description": "35% off on eyewear",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Hermès",
            "description": "Special discount on scarves",
        },
        {
            "_id": str(ObjectId()),
            "brand": "Burberry",
            "description": "Free gift with any purchase over $200",
        },
        # Add more fashion deals as needed
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