# Luau-HttpSpy
HttpSpy made in Luau that tracks requests being sent to an endpoint (GET, or POST)

```mermaid
graph TD
A[Request sent] --> B[HttpSpy catches requests]
B --> C[HttpSpy prompts user: Allow connection to endpoint?]
C -->|Yes| D[Request Sent]
C -->|No| E[Request Blocked]
```
