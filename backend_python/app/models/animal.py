from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class Animal(BaseModel):
    # El ID de negocio (QR) es obligatorio y debe ser String
    codigoQR: str = Field(..., example="VACA001")
    
    # Datos físicos del animal
    raza: str = Field(..., example="Holstein")
    edad: int = Field(..., ge=0, example=3)
    peso: float = Field(..., ge=0, example=450.5)
    
    # Datos para la Sincronización (Historia de Usuario 5)
    fecha_registro: datetime = Field(default_factory=datetime.now)
    ultima_modificacion: datetime = Field(default_factory=datetime.now)
    
    # Este campo indica si ya está en la nube (siempre True al llegar al backend)
    sincronizado: bool = True

    class Config:
        # Esto permite que el JSON se maneje correctamente en Python
        populate_by_name = True