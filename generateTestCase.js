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

function generateProcedureResource(
  id,
  procSystem,
  procCode,
  procDisplay,
  procDescription,
  performedDate
) {
  return {
    resourceType: "Procedure",
    id: `ccs-${id}-proc`,
    status: "completed",
    code: {
      coding: [
        {
          system: procSystem,
          code: procCode,
          display: procDisplay,
        },
      ],
      text: procDescription,
    },
    subject: {
      reference: `Patient/ccs-${id}`,
    },
    performer: [
      {
        actor: {
          reference: "Practitioner/grahek-lawrence",
          display: "Larry Grahek",
        },
      },
    ],
    performedDateTime: performedDate.toISOString().split("T")[0],
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
  const procSystem = process.argv[6];
  const procCode = process.argv[7];
  const procDisplay = process.argv[8];
  const procDescription = process.argv[9];
  const maxInterval = parseInt(process.argv[10]);

  if (
    !id ||
    !description ||
    !expectedOutcome ||
    !birthDate ||
    !procSystem ||
    !procCode ||
    !procDisplay ||
    !procDescription ||
    !maxInterval
  ) {
    console.error(
      "Usage: node generateResources.js <id> <description> <expectedOutcome> <birthDate> <procSystem> <procCode> <procDisplay> <procDescription> <maxInterval>"
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
  const procedure = generateProcedureResource(
    id,
    procSystem,
    procCode,
    procDisplay,
    procDescription,
    performedDate
  );

  const baseDir = `input/tests/plandefinition/ColorectalCancerScreeningCDS/ccs-${id}`;
  saveResource(patient, `${baseDir}/Patient/ccs-${id}.json`);
  saveResource(procedure, `${baseDir}/Procedure/ccs-${id}-proc.json`);

  console.log("Resources generated successfully.");
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
