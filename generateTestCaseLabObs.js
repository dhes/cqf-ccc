const fs = require("fs-extra");
const path = require("path");

function generatePatientResource(id, description, expectedOutcome, birthDate) {
  return {
    resourceType: "Patient",
    id: `ccs-${id}`,
    identifier: [
      {
        system: "http://example.org/colon-cancer-screening",
        value: id,
      },
    ],
    extension: [
      {
        url: "http://example.org/fhir/StructureDefinition/patient-annotation",
        valueString: `${description} => ${expectedOutcome}`,
      },
    ],
    name: [
      {
        family: "Nobody",
        given: ["Absolutely"],
      },
    ],
    birthDate: birthDate,
    gender: "male",
    active: true,
    deceasedBoolean: false,
  };
}

function generateObservationResource(
  id,
  obsSystem,
  obsCode,
  obsDisplay,
  obsDescription,
  effectiveDate
) {
  return {
    resourceType: "Observation",
    id: `ccs-${id}-obs`,
    status: "final",
    category: [
      {
        coding: [
          {
            system:
              "http://terminology.hl7.org/CodeSystem/observation-category",
            code: "laboratory",
          },
        ],
      },
    ],
    code: {
      coding: [
        {
          system: obsSystem,
          code: obsCode,
          display: obsDisplay,
        },
      ],
      text: obsDescription,
    },
    subject: {
      reference: `Patient/ccs-${id}`,
    },
    performer: [
      {
        reference: "Organization/clinical-labs-hawaii",
      },
    ],
    effectiveDateTime: effectiveDate.toISOString().split("T")[0],
  };
}

function saveResource(resource, filePath) {
  fs.ensureDirSync(path.dirname(filePath));
  fs.writeJsonSync(filePath, resource, { spaces: 2 });
}

// Script Execution
async function main() {
  const id = process.argv[2];
  const description = process.argv[3];
  const expectedOutcome = process.argv[4];
  const birthDate = process.argv[5];
  const obsSystem = process.argv[6];
  const obsCode = process.argv[7];
  const obsDisplay = process.argv[8];
  const obsDescription = process.argv[9];
  const maxInterval = parseInt(process.argv[10]);

  if (
    !id ||
    !description ||
    !expectedOutcome ||
    !birthDate ||
    !obsSystem ||
    !obsCode ||
    !obsDisplay ||
    !obsDescription ||
    !maxInterval
  ) {
    console.error(
      "Usage: node generateResources.js <id> <description> <expectedOutcome> <birthDate> <obsSystem> <obsCode> <obsDisplay> <obsDescription> <maxInterval>"
    );
    process.exit(1);
  }

  const referenceDate = new Date("2024-01-01");
  const performedDate = new Date(referenceDate);
  // performedDate.setFullYear(referenceDate.getFullYear() - maxInterval / 2);
  const monthsOffset = Math.round((maxInterval * 12) / 2); // Convert years to months and divide by 2
  performedDate.setFullYear(referenceDate.getFullYear());
  performedDate.setMonth(referenceDate.getMonth() - monthsOffset);

  const patient = generatePatientResource(
    id,
    description,
    expectedOutcome,
    birthDate
  );
  const observation = generateObservationResource(
    id,
    obsSystem,
    obsCode,
    obsDisplay,
    obsDescription,
    performedDate
  );

  const baseDir = `input/tests/plandefinition/ColorectalCancerScreeningCDS/ccs-${id}`;
  saveResource(patient, `${baseDir}/Patient/ccs-${id}.json`);
  saveResource(observation, `${baseDir}/Observation/ccs-${id}-obs.json`);

  console.log("Resources generated successfully.");
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
