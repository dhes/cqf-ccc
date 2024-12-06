library ColorectalCancerScreeningCDS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC
include ColorectalCancerElements called CCE

// parameter ReferenceDate is now defined in CCE

context Patient

define A:
  ( singleton from ( Patient.extension E
        where E.url = 'http://example.org/fhir/StructureDefinition/patient-annotation'
    )
  ).value.value

// Handy troubleshooting definitions
// define "PatientDeceasedIsNull": Patient.deceased is null
// define "PatientDeceasedIsBoolean": Patient.deceased is Boolean
// define "PatientDeceasedIsFalse": Patient.deceased = false
// define "PatientDeceasedIsDateTime": Patient.deceased is dateTime
// define "PatientDeceasedValue": Patient.deceased

define ActiveAndAlive:
  Patient.active = true
    and (
      Patient.deceased is null
      or (Patient.deceased is boolean and Patient.deceased = false)
    )

define PatientAge: AgeInYearsAt(CCE.ReferenceDate)

define "Is Recommendation Applicable":
  ActiveAndAlive
    and PatientAge in Interval[50,75]
    and not CCE."Has Appropriate Colorectal Cancer Screening"
    and not CCE."Has Active Malignant Neoplasm"
    and not exists ( CCE."Total Colectomy Performed" )

define "Get Card Summary":
  if "Is Recommendation Applicable" then 'Recommend colorectal cancer screening' 
    else 'Colorectal cancer screening up to date'

define "Get Card Detail":
  if "Is Recommendation Applicable" then 'Patient meets the inclusion criteria for appropriate colorectal cancer screening, but has ' + Rationale + '.' 
    else 'Colorectal cancer screening up to date: ' + Rationale + '.'

define "Rationale":
  Coalesce({
    // 'most recent FOBT issued on ' + ToString(date from CCE."Most Recent Fecal Occult Blood Test Result".issued),
    // 'most recent FIT DNA issued on ' + ToString(date from CCE."Most Recent Fecal Immunochemical Test DNA Result".issued),
    // 'most recent CT Colonography performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent CT Colonography Performed".performed)),
    'most recent Flexible Sigmoidoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Flexible Sigmoidoscopy Performed".performed)), 
    'most recent Colonoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Colonoscopy Performed".performed)), 
    'no evidence of appropriate screening' }
  )

define "Get Card Indicator":
  if "Is Recommendation Applicable" then 'asap' 
    else 'routine'

