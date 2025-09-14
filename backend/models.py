from sqlalchemy import Column, Integer, Float, String
from database import Base

class Bill(Base):
    __tablename__ = "bills"

    id = Column(Integer, primary_key=True, index=True)
    raw_text = Column(String)
    total_amount = Column(Float, nullable=True)
    tax = Column(Float, nullable=True)
    other_charges = Column(Float, nullable=True)
