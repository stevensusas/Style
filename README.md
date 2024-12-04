# Style

Steven, Angelina, Stan's CIS 1951 final project.

Backend base url: https://style-backend-315518144493.us-east1.run.app

## Course Concept 1: Network Requests

To accomodate user authentication functionality and allow user to view and trade deals, we created a dedicated backend server based on FastAPI framework, containerized the backend using Docker,and deployed it on GCP Cloud Run. The backend based URL is pasted above. The APIService struct in the Swift project contains the methods to submit POST/GET requests to all the defind backend endpoints, allowing the Swift application to serve as the client side in the client-server-database full stack architecture.

## Course Concept 2: Persistent Data Storage

To allow user auth and for users to save their deals, we utilized two persistent data storage solutions: MongoDB and UserDefaults. MongoDB was used to store user authentication data and each user's collection of deals, while UserDefaults is used as a caching layer within the full-stack architecture. Specifically, it caches three keys: the deal of the day (currentDealData), the last time the deal of the day was updated (lastDealUpdateTime), and whether the user has already taken the deal of the day (dealSavedToday). UserDefaults helps us avoid unnecessary network requests to the backend server to check if the user has already taken the deal of the day and implement the FeedView effectively.

## Tech Stack & Architecture

![Blank diagram (4)](https://github.com/user-attachments/assets/ee6d369e-4d0a-46cd-b41d-e17f593e08d4)
