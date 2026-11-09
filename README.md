Backend y Frontend en Docker + Kubernetes


proyecto/
├── api\_backend/api\_backend/   # Backend: Spring Boot + JWT + CRUD de usuarios + upload
│   └── Dockerfile
├── appkc/                     # Frontend: app Flutter (compilada para web)
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/
│   ├── backend.yaml           # Deployment (2 réplicas) + Service NodePort 30080
│   └── frontend.yaml          # Deployment (1 réplica) + Service NodePort 30081
├── README.md



Con qué está hecho

* **Backend:** Java 17, Spring Boot, PostgreSQL en Neon, JWT y arquitectura hexagonal.
* **Frontend:** Flutter Web servido con nginx (MVVM).
* **Contenedores:** Docker.
* **Orquestación:** Kubernetes en Docker Desktop.



## 

