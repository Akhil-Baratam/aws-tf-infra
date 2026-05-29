start:
	COMPOSE_BAKE=true docker compose up --build

stop:
	COMPOSE_BAKE=true docker compose down

build-ui:
	docker build -t ui_service ./ui

build-insurance-service:
	docker build -t insurance_service --build-arg APP_PATH=insurance_service ./api

build-patient-service:
	docker build -t patient_service --build-arg APP_PATH=patient_service ./api

build-pricing-service:
	docker build -t pricing_service --build-arg APP_PATH=pricing_service ./api