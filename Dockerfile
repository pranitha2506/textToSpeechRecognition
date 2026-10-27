
FROM python:3.12-slim

WORKDIR /tests

RUN pip install --no-cache-dir pytest selenium

COPY tests/test_selenium.py .

CMD ["python", "-m", "pytest", "-v", "test_selenium.py"]
