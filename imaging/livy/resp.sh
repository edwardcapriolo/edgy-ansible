#curl -X POST --data '{"kind": "spark"}' -H "Content-Type: application/json" localhost:8998/sessions
#curl -X POST -H 'Content-Type: application/json' -d '{"code":"1 + 1"}' localhost:8998/sessions/0/statements
curl -X GET -H 'Content-Type: application/json' http://localhost:8998/sessions/0/statements/0
