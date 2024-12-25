library ColorectalCancerScreeningCDS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC
include ColorectalCancerElements called CCE

// parameter ReferenceDate is now defined in CCE

context Patient

define `1-patient-annotation`:
  ( singleton from ( Patient.extension E
        where E.url = 'http://example.org/fhir/StructureDefinition/patient-annotation'
    )
  ).value.value

// Handy Active and Alive deceased troubleshooting definitions
// define "2-PatientDeceasedIsNull": Patient.deceased is null
// define "3-PatientDeceasedIsBoolean": Patient.deceased is Boolean
// define "4-PatientDeceasedIsFalse": Patient.deceased = false
// define "5-PatientDeceasedIsDateTime": Patient.deceased is dateTime
// define "6-PatientDeceasedValue": Patient.deceased

// handy colonoscopy troubleshooting definitions
define `2-date from (date from CCE.ReferenceDate - 10 years)`:
  date from (date from CCE.ReferenceDate - 10 years)
define "3-ColonoscopyPerformedWithin10Years":
	exists CCE."Colonoscopy Performed Within 10 Years"

define ActiveAndAlive:
  Patient.active = true
    and (
      Patient.deceased is null
      or (Patient.deceased is boolean and Patient.deceased = false)
    )

define PatientAge: AgeInYearsAt(CCE.ReferenceDate)

define "Applicable":
  ActiveAndAlive
    and PatientAge in Interval[50,75]
    and not CCE.TestUpToDate
    and not CCE."Has Active Malignant Neoplasm"
    and not exists ( CCE."Total Colectomy Performed" )

define "Get Card Summary":
  if "Applicable" then 'Recommend colorectal cancer screening' 
    else 'Colorectal cancer screening up to date'

define "Get Card Detail":
  if "Applicable" then 'Patient meets the inclusion criteria for appropriate colorectal cancer screening, but has ' + Rationale + '.' 
    else 'Colorectal cancer screening up to date: ' + Rationale + '.'

define "Rationale":
  Coalesce({
    'most recent FOBT effective on ' + ToString(date from CCE."Most Recent Fecal Occult Blood Test Result".effective),
    'most recent FIT DNA effective on ' + ToString(date from CCE."Most Recent Fecal Immunochemical Test DNA Result".effective),
    'most recent CT Colonography performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent CT Colonography Performed".performed)),
    'most recent Flexible Sigmoidoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Flexible Sigmoidoscopy Performed".performed)), 
    'most recent Colonoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Colonoscopy Performed".performed)), 
    'no evidence of appropriate screening' }
  )

define "Get Card Indicator":
  'routine'

