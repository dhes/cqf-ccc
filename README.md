This is my version of cqf-ccc. I have pushed this bundle to my personal instance of HAPI FHIR JPA server. PlanDefinition/$apply works but cdshooks does not. 

Here is the terminal command to push the bundle to a local HAPI FHIR JPA server running on port 8080. 
```
curl -d "@bundles/plandefinition/ColorectalCancerScreeningCDS/ColorectalCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```