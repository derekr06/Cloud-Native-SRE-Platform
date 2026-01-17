from fastapi import FastAPI
from prometheus_client import Counter, generate_latest
from starlette.responses import Response

app = FastAPI(title = "Cloud Native Reliability Service")

# Prometheus metric
REQUEST_COUNT= Counter(
    "http_requests_total",
    "Total HTTP requests"
)

# Kubernetes health checks
@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/")
def show():
    return{"message: service is running. Put endpoint. Ex: '/health' "}

# Prometheus Scraping 
@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type="text/plain")

@app.middleware("http")
async def count_requests(request, call_next):
    REQUEST_COUNT.inc()
    response = await call_next(request)
    return response
