import os
from flask import Flask, request, jsonify

app = Flask(__name__)
API_KEY = os.environ.get("API_KEY", "")


def authorized():
    return bool(API_KEY) and request.headers.get("X-API-Key") == API_KEY


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/tools/shipping-quote")
def shipping_quote():
    if not authorized():
        return jsonify(error="unauthorized"), 401
    data = request.get_json(silent=True) or {}
    postal = str(data.get("postalCode", "")).strip()
    weight = data.get("weightKg")
    if not postal or not isinstance(weight, (int, float)) or weight <= 0:
        return jsonify(error="postalCode and a positive weightKg are required"), 400
    price = round(5 + 2.5 * weight, 2)
    app.logger.info("shipping-quote postal=%s weight=%s", postal, weight)
    return jsonify(carrier="MockExpress", price=price, currency="USD", etaDays=3)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
