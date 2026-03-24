from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


# -----------------------------
# Historia 3: Modelo de Vacuna
# -----------------------------
class Vacuna(BaseModel):
    tipo: str = Field(..., example="Fiebre Aftosa")
    dosis: str = Field(..., example="5 ml")
    fecha_aplicacion: datetime = Field(default_factory=datetime.now)


# -----------------------------
# Historia 4: Modelo Revision Medica
# -----------------------------
class RevisionMedica(BaseModel):
    fecha_revision: datetime = Field(default_factory=datetime.now)
    observaciones: str = Field(
        ..., example="Animal en buen estado de salud"
    )
    estado_salud: str = Field(
        ..., example="En tratamiento"
    )  # Excelente, En tratamiento, Crítico

    veterinario: Optional[str] = "Dr. Perlaza"


# -----------------------------
# Modelo principal Animal
# -----------------------------
class Animal(BaseModel):

    # ID del animal (QR)
    codigoQR: str = Field(..., example="VACA001")

    # Datos físicos
    raza: str = Field(..., example="Holstein")
    edad: int = Field(..., ge=0, example=3)
    peso: float = Field(..., ge=0, example=450.5)

    # Historia 3 y 4
    historial_vacunas: List[Vacuna] = []
    historial_clinico: List[RevisionMedica] = []

    # Historia 5 → sincronización
    fecha_registro: datetime = Field(default_factory=datetime.now)
    ultima_modificacion: datetime = Field(default_factory=datetime.now)

    # Indica si está sincronizado con la nube
    sincronizado: bool = True

    class Config:
        populate_by_name = True