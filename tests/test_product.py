"""Tests for ProductCard model."""

import pytest
from app.schemas.inventory import InventoryStatus
from app.schemas.product import ProductCard


def test_product_card_fields():
    product = ProductCard(
        id=1,
        name="Widget",
        price=9.99,
        inventory_status=InventoryStatus.in_stock,
    )
    assert product.id == 1
    assert product.name == "Widget"
    assert product.price == 9.99
    assert product.inventory_status == InventoryStatus.in_stock


def test_product_price_is_float():
    product = ProductCard(
        id=2, name="Gadget", price=19.99, inventory_status=InventoryStatus.low_stock
    )
    assert isinstance(product.price, float)


def test_invalid_inventory_status_raises():
    with pytest.raises(Exception):
        ProductCard(id=3, name="Thing", price=1.0, inventory_status="unknown")
