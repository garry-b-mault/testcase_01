from pydantic import BaseModel
from app.schemas.inventory import InventoryStatus


class ProductCard(BaseModel):
    id: int
    name: str
    price: float
    inventory_status: InventoryStatus
