This is my version of cqf-ccc. I have pushed this bundle to my personal instance of HAPI FHIR JPA server. PlanDefinition/$apply works but cdshooks does not. 

Here is the terminal command to push the bundle to a local HAPI FHIR JPA server running on port 8080. 
```
curl -d "@bundles/plandefinition/ColorectalCancerScreeningCDS/ColorectalCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

2024-03-2024

The PlanDefinition in hiv-cds is structured differently than this one. In hiv-cds there is are three layers of action. In this there is one. The first layer of action in hiv-cds is always true. I'm not really sure why it's there. The second layer is an array of six scenarios (never tested, MSM condition, etc). The third level is the choices on the response form - basically, test now, snooze for a little while, snooze for a longer while, patient declined. To bring this into alignment I might just add a 'true' action layer to the PlanDefinition. 

# Edges

There are so many different ways to screen. For now we just have colonoscopy tests. 

|Name|Resource|base?|aspect|action?|
|---|---|---|---|---|
|base|Patient|Y|-|true|

# Troubleshooting

note: MostRecent is only used in the rationale cql

Next proposed test cases
- ct-colonography-just-recent-enough => negative
- ct-colonography-not-recent-enough => positive
- fobt-just-recent-enough => negative
- fobt-not-recent-enough => positive
- fit-just-recent-enough => negative
- fit-not-recent-enough => positive
- colon-cancer => negative
- status-total-colectomy => negative
