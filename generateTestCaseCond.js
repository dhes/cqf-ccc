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

function generateConditionResource(
  id,
  condSystem,
  condCode,
  condDisplay,
  condDescription,
  onsetDate
) {
  return {
    resourceType: "Condition",
    id: `ccs-${id}-cond`,
    clinicalStatus: [
      {
        coding: [
          {
            system: "http://terminology.hl7.org/CodeSystem/condition-clinical",
            version: "0.5.0",
            code: "active",
            display: "Active",
          },
        ],
      },
    ],
    verificationStatus: [
      {
        coding: [
          {
            system:
              "http://terminology.hl7.org/CodeSystem/condition-ver-status",
            version: "0.5.0",
            code: "confirmed",
            display: "Confirmed",
          },
        ],
      },
    ],
    code: {
      coding: [
        {
          system: condSystem,
          code: condCode,
          display: condDisplay,
        },
      ],
      text: condDescription,
    },
    subject: {
      reference: `Patient/ccs-${id}`,
    },
    onsetDateTime: onsetDate
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
  const condSystem = process.argv[6];
  const condCode = process.argv[7];
  const condDisplay = process.argv[8];
  const condDescription = process.argv[9];
  const onsetDate = process.argv[10];

  if (
    !id ||
    !description ||
    !expectedOutcome ||
    !birthDate ||
    !condSystem ||
    !condCode ||
    !condDisplay ||
    !condDescription ||
    !onsetDate
  ) {
    console.error(
      "Usage: node generateResources.js <id> <description> <expectedOutcome> <birthDate> <condSystem> <condCode> <condDisplay> <condDescription>"
    );
    process.exit(1);
  }

  // const referenceDate = new Date("2024-01-01");
  // const onsetDate = new Date(referenceDate);
  // onsetDate.setFullYear(referenceDate.getFullYear() - maxInterval / 2);
  // const monthsOffset = Math.round((maxInterval * 12) / 2); // Convert years to months and divide by 2
  // performedDate.setFullYear(referenceDate.getFullYear());
  // performedDate.setMonth(referenceDate.getMonth() - monthsOffset);

  const patient = generatePatientResource(
    id,
    description,
    expectedOutcome,
    birthDate
  );
  const condition = generateConditionResource(
    id,
    condSystem,
    condCode,
    condDisplay,
    condDescription,
    onsetDate
  );

  const baseDir = `input/tests/plandefinition/ColorectalCancerScreeningCDS/ccs-${id}`;
  saveResource(patient, `${baseDir}/Patient/ccs-${id}.json`);
  saveResource(condition, `${baseDir}/Condition/ccs-${id}-cond.json`);

  console.log("Resources generated successfully.");
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
