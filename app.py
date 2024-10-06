from flask import Flask, request, jsonify, render_template
import random
import json
import torch
from model import NeuralNet
from nltk_utils import tokenize, bag_of_words
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

with open('intents.json', 'r') as json_data:
    intents = json.load(json_data)

FILE = "data.pth"
data = torch.load(FILE)

input_size = data["input_size"]
hidden_size = data["hidden_size"]
output_size = data["output_size"]
all_words = data['all_words']
tags = data['tags']
model_state = data["model_state"]

model = NeuralNet(input_size, hidden_size, output_size).to(device)
model.load_state_dict(model_state)
model.eval()

@app.route('/test', methods=['GET'])
def test():
    return jsonify({"message": "Connection successful!"})

@app.route('/', methods=['POST'])
def chat():
    user_input = request.json.get('message')  # Get user message from the request
    print(f"User input: {user_input}")  # Debug output
    if not user_input:
        return jsonify({"response": "Please provide a valid message."})

    # Tokenize, get bag of words and predict the intent
    sentence = tokenize(user_input)
    X = bag_of_words(sentence, all_words)
    X = X.reshape(1, X.shape[0])
    X = torch.from_numpy(X).to(device)

    output = model(X)
    _, predicted = torch.max(output, dim=1)
    tag = tags[predicted.item()]

    # Check prediction confidence
    probs = torch.softmax(output, dim=1)
    prob = probs[0][predicted.item()]

    if prob.item() > 0.75:
        for intent in intents['intents']:
            if tag == intent["tag"]:
                response = random.choice(intent['responses'])
                print(f"Response: {response}")  # Debug output
                return jsonify({"response": response})
    else:
        return jsonify({"response": "I do not understand..."})

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5001)
