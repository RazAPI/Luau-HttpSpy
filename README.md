# Luau-HttpSpy
HttpSpy made in Luau that tracks requests being sent to an endpoint (GET, or POST)

**Version** 1.1.5
```mermaid
graph TD
A[Request Sent] --> B[HttpSpy Catches Request]
B --> C[HttpSpy Prompts User: Allow connection to endpoint?]

YesNode[Yes]
NoNode[No]

C --> YesNode --> D[Request Sent]
C --> NoNode --> E[Request Blocked]

style YesNode fill:none,stroke:none
style NoNode fill:none,stroke:none
```
