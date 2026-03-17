from fastapi import FastAPI
from app.routes.ganado import router as ganado_router
from app.database import test_connection

# 1. Crear la instancia de la aplicación
app = FastAPI(
    title="AgroScan API",
    description="Backend para el control de trazabilidad ganadera (Offline-First)",
    version="1.0.0"
)

# 2. Evento de inicio: Verificar conexión con MongoDB Atlas
@app.on_event("startup")
async def startup_db_client():
    if await test_connection():
        print(">>> API conectada exitosamente a MongoDB Atlas <<<")
    else:
        print("XXX Error crítico: No se pudo conectar a la base de datos XXX")

# 3. Incluir las rutas del módulo de ganado
# Prefijamos con /ganado para que las rutas sean: /ganado/ y /ganado/sync
app.include_router(ganado_router, prefix="/ganado", tags=["Ganado"])

# 4. Ruta de bienvenida (Root)
@app.get("/", tags=["General"])
async def root():
    return {"mensaje": "Bienvenido a la API de AgroScan - Sistema de Control Ganadero"}