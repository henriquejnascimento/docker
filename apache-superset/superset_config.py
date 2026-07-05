from flask import Flask
import os

SQLALCHEMY_DATABASE_URI = os.getenv(
    "SQLALCHEMY_DATABASE_URI",
    "postgresql://postgres:root@postgres:5432/superset"
)

SECRET_KEY = "x9K2mP8vQ4zT7wL1cR6sN3bJ8hG5fD2aA9zX1cV7bM"