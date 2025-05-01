curl -X POST http://localhost:8000/v2/models/onnx_model/infer \
     -H "Content-Type: application/json" \
     -d @Test_input/onnx.json

echo

curl -X POST http://localhost:8000/v2/models/simple_model/infer \
     -H "Content-Type: application/json" \
     -d @Test_input/py.json

echo

curl -X POST http://localhost:8000/v2/models/ensemble_model/infer \
     -H "Content-Type: application/json" \
     -d @Test_input/ens.json