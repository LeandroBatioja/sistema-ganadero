import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

# Cargamos variables de entorno
load_dotenv()

MONGO_URL = os.getenv("MONGO_URL")
DB_NAME = os.getenv("DB_NAME")

# Cliente asíncrono para MongoDB
client = AsyncIOMotorClient(MONGO_URL)

# Referencia a la base de datos 'ganaderia'
database = client[DB_NAME]

# Función para verificar si el backend "ve" a MongoDB Atlas
async def test_connection():
    try:
        await client.admin.command('ping')
        return True
    except Exception as e:
        print(f"Error conectando a Mongo: {e}")
        return False