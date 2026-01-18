import yaml, os, datetime

REQ = "pm_ai/requirements.md"
OUT = "spec/usecases.schema.yaml"
os.makedirs("spec", exist_ok=True)

usecases = [
  {"domain":"auth","name":"Login","type":"command"},
  {"domain":"auth","name":"Logout","type":"command"},
  {"domain":"order","name":"CreateOrder","type":"command"},
  {"domain":"order","name":"GetOrderList","type":"query"},
  {"domain":"shipping","name":"CreateShipping","type":"command"},
  {"domain":"billing","name":"CreateInvoice","type":"command"},
  {"domain":"billing","name":"GetInvoiceList","type":"query"},
]

with open(OUT,"w") as f:
    yaml.dump({"generated":str(datetime.datetime.now()),
               "usecases":usecases}, f, sort_keys=False)

print(f"OK: generated {OUT}")
