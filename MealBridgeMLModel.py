from flask import Flask, request, jsonify
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
import datetime
import os

app = Flask(__name__)


def predict_next_day_waste(history_data):

    # 1. Convert JSON to DataFrame
    if not history_data:
        return 0.0
        
    df = pd.DataFrame(history_data)
    
    # 2. Prepare Features (X) and Target (y)
    # X = Day of Week (0-6)
    # y = Quantity (kg)
    X = df[['dayIndex']] 
    y = df['totalWeight']
    
    # 3. Train Model (Random Forest is great for pattern matching)
    # n_estimators=10 means 10 trees (fast and light)
    model = RandomForestRegressor(n_estimators=10, random_state=42)
    model.fit(X, y)
    
    # 4. Determine "Tomorrow's" Day of Week
    # We get today's day (0-6) and add 1. If it's 6 (Sun), next is 0 (Mon).
    today = datetime.datetime.today().weekday()
    tomorrow = (today + 1) % 7
    
    # 5. Predict
    prediction = model.predict([[tomorrow]])
    
    return float(prediction[0])

# --- API ENDPOINT ---
@app.route('/predict', methods=['POST'])
def get_prediction():
    try:
        data = request.json 
        
        predicted_qty = predict_next_day_waste(data)
        
        return jsonify({
            "status": "success",
            "predictedQuantity": round(predicted_qty, 2),
            "message": f"Predicted waste for tomorrow: {round(predicted_qty, 2)} kg"
        })
        
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)