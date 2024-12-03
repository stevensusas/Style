from pymongo import MongoClient
from bson import ObjectId

# MongoDB connection
client = MongoClient(
    "mongodb+srv://default:12345678abc@style.wxs7m.mongodb.net/?retryWrites=true&w=majority&appName=Style"
)
db = client["default"]
deals_collection = db["deals"]
users_collection = db["users"]

# Sample deals data
deals = [
    {"description": "50% off at Nike - Valid until end of month"},
    {"description": "Buy one get one free at Adidas"},
    {"description": "30% off all shoes at Foot Locker"},
    {"description": "$20 off orders over $100 at ASOS"},
    {"description": "Free shipping at Zara"},
    {"description": "20% student discount at H&M"},
    {"description": "15% off first purchase at Uniqlo"},
    {"description": "$15 off orders over $75 at Urban Outfitters"},
    {"description": "40% off clearance items at Nordstrom"},
    {"description": "25% off sitewide at Lululemon"},
    {"description": "Free gift with purchase at Sephora"},
    {"description": "10% off your first order at SSENSE"},
    {"description": "3 for 2 on all basics at GAP"},
    {"description": "Members get 20% off at Macy's"},
    {"description": "$50 off orders over $200 at Bloomingdale's"},
    {"description": "Free returns at ASOS"},
    {"description": "2 for $30 t-shirts at Old Navy"},
    {"description": "Extra 10% off sale items at Zara"},
    {"description": "Free shipping over $50 at Nike"},
    {"description": "Student discount - 15% off at Adidas"},
    {"description": "Buy 2 get 1 free at Foot Locker"},
    {"description": "30% off new arrivals at H&M"},
    {"description": "Spend $100 get $20 back at Uniqlo"},
    {"description": "Members only: 25% off at Urban Outfitters"},
    {"description": "Flash sale: 40% off at Nordstrom"},
]


def clear_database():
    # Clear existing deals and users
    deals_collection.delete_many({})
    users_collection.delete_many({})
    print("Successfully cleared all deals and users from database")


def seed_database():
    # First clear the database
    clear_database()

    # Insert new deals
    for deal in deals:
        deal["_id"] = str(ObjectId())  # Generate a new ObjectId as string
        deals_collection.insert_one(deal)

    print(f"Successfully seeded {len(deals)} deals")

    # Verify the deals were added
    deals_count = deals_collection.count_documents({})
    users_count = users_collection.count_documents({})
    print(f"Total deals in database: {deals_count}")
    print(f"Total users in database: {users_count}")

    # Print first few deals as sample
    print("\nSample deals:")
    for deal in deals_collection.find().limit(3):
        print(f"- {deal['description']}")


if __name__ == "__main__":
    seed_database()
