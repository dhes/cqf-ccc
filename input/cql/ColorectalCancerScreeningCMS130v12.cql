// Start with logic for CMSc12
//https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS130v12.html

//////////////////////////////////////
//                                  //
//  add 'library',                  //
//  'using', 'include', 'parameter' //
//  and 'context' statements here   //
//                                  //
/////////////////////////////////////

// for simplicity remove Qualifying Encounters
// AdultOutpatientEncounters.Qualifying Encounters
// ( ["Encounter, Performed": "Office Visit"]
//   union ["Encounter, Performed": "Annual Wellness Visit"]
//   union ["Encounter, Performed": "Preventive Care Services Established Office Visit, 18 and Up"]
//   union ["Encounter, Performed": "Preventive Care Services Initial Office Visit, 18 and Up"]
//   union ["Encounter, Performed": "Home Healthcare Services"] 
//   union ["Encounter, Performed": "Online Assessments"]
//   union ["Encounter, Performed": "Telephone Visits"] ) ValidEncounter
//   where ValidEncounter.relevantPeriod during day of "Measurement Period"
 
// For simplicity remove frailty and AI (Advanced Illness) criteria
// AIFrailLTCF.Has Criteria Indicating Frailty
// exists ( ["Device, Order": "Frailty Device"] FrailtyDeviceOrder
//     where FrailtyDeviceOrder.authorDatetime during day of "Measurement Period"
// )
//   or exists ( ["Assessment, Performed": "Medical equipment used"] EquipmentUsed
//       where EquipmentUsed.result in "Frailty Device"
//         and Global."NormalizeInterval" ( EquipmentUsed.relevantDatetime, EquipmentUsed.relevantPeriod ) ends during day of "Measurement Period"
//   )
//   or exists ( ["Diagnosis": "Frailty Diagnosis"] FrailtyDiagnosis
//       where FrailtyDiagnosis.prevalencePeriod overlaps "Measurement Period"
//   )
//   or exists ( ["Encounter, Performed": "Frailty Encounter"] FrailtyEncounter
//       where FrailtyEncounter.relevantPeriod overlaps "Measurement Period"
//   )
//   or exists ( ["Symptom": "Frailty Symptom"] FrailtySymptom
//       where FrailtySymptom.prevalencePeriod overlaps "Measurement Period"
//   )
 
// AIFrailLTCF.Has Dementia Medications in Year Before or During Measurement Period
// exists (["Medication, Active": "Dementia Medications"] DementiaMedication
//   where Global."NormalizeInterval" ( DementiaMedication.relevantDatetime, DementiaMedication.relevantPeriod ) overlaps Interval[start of "Measurement Period" - 1 year, 
//   end of "Measurement Period"])
 
// AIFrailLTCF.Has Inpatient Encounter with Advanced Illness
// exists( ["Encounter, Performed": "Acute Inpatient"] InpatientEncounter
//   where exists ( InpatientEncounter.diagnoses Diagnosis
//       where Diagnosis.code in "Advanced Illness"
//   )
//     and InpatientEncounter.relevantPeriod starts during day of Interval[start of "Measurement Period" - 1 year, 
//     end of "Measurement Period"])
 
// AIFrailLTCF.Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service
// exists (
// from
//   "Outpatient Encounters with Advanced Illness" OutpatientEncounter1,
//   "Outpatient Encounters with Advanced Illness" OutpatientEncounter2
//   where OutpatientEncounter2.relevantPeriod ends 1 day or more after day of 
//   end of OutpatientEncounter1.relevantPeriod
//   return OutpatientEncounter1
//   )
 
// AIFrailLTCF.Is Age 66 or Older Living Long Term in a Nursing Home
// ( AgeInYearsAt(date from 
//     end of "Measurement Period"
//   )>= 66
// )
//   and ( ( Last(["Assessment, Performed": "Housing status"] HousingStatus
//         where Global."NormalizeInterval"(HousingStatus.relevantDatetime, HousingStatus.relevantPeriod)ends on or before 
//         end of "Measurement Period"
//         sort by 
//         end of Global."NormalizeInterval"(relevantDatetime, relevantPeriod)asc
//     )) LastHousingStatus
//       where LastHousingStatus.result ~ "Lives in a nursing home (finding)"
//   ) is not null
 
// AIFrailLTCF.Is Age 66 or Older with Advanced Illness and Frailty
// ( AgeInYearsAt(date from 
//     end of "Measurement Period"
//   )>= 66
//     and "Has Criteria Indicating Frailty"
//     and ( "Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service"
//         or "Has Inpatient Encounter with Advanced Illness"
//         or "Has Dementia Medications in Year Before or During Measurement Period"
//     )
// )
 
// AIFrailLTCF.Outpatient Encounters with Advanced Illness
// ( ["Encounter, Performed": "Outpatient"]
//   union ["Encounter, Performed": "Observation"]
//   union ["Encounter, Performed": "Emergency Department Visit"]
//   union ["Encounter, Performed": "Nonacute Inpatient"] ) OutpatientEncounter
//   where exists ( OutpatientEncounter.diagnoses Diagnosis
//       where Diagnosis.code in "Advanced Illness"
//   )
//     and OutpatientEncounter.relevantPeriod starts during day of Interval[start of "Measurement Period" - 1 year, 
//     end of "Measurement Period"]
 
// cqf-ccc moves this to Colorectal Cancer Elements
Colonoscopy Performed
["Procedure, Performed": "Colonoscopy"] Colonoscopy
  where Global."NormalizeInterval" ( Colonoscopy.relevantDatetime, Colonoscopy.relevantPeriod ) ends during day of Interval[start of "Measurement Period" - 9 years, 
  end of "Measurement Period"]
 
// cqf-ccc moves this to Colorectal Cancer Elements
CT Colonography Performed
["Diagnostic Study, Performed": "CT Colonography"] Colonography
  where Global."NormalizeInterval" ( Colonography.relevantDatetime, Colonography.relevantPeriod ) ends during day of Interval[start of "Measurement Period" - 4 years, 
  end of "Measurement Period"]
 
Denominator
"Initial Population"
 
// Denominator Exclusions
// Hospice."Has Hospice Services"
//   or exists "Malignant Neoplasm"
//   or exists "Total Colectomy Performed"
//   or AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
//   or AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
//   or PalliativeCare."Palliative Care in the Measurement Period"
 
// cqf-ccc moves this to Colorectal Cancer Elements under a slightly different name
Fecal Immunochemical Test DNA Performed
["Laboratory Test, Performed": "FIT DNA"] FitDNA
  where FitDNA.result is not null
    and Global."LatestOf" ( FitDNA.relevantDatetime, FitDNA.relevantPeriod ) during day of Interval[start of "Measurement Period" - 2 years, 
    end of "Measurement Period"]

// cqf-ccc moves this to Colorectal Cancer Elements under a slightly different name
Fecal Occult Blood Test Performed
["Laboratory Test, Performed": "Fecal Occult Blood Test (FOBT)"] FecalOccultResult
  where FecalOccultResult.result is not null
    and Global."LatestOf" ( FecalOccultResult.relevantDatetime, FecalOccultResult.relevantPeriod ) during "Measurement Period"

// cqf-ccc moves this to Colorectal Cancer Elements
Flexible Sigmoidoscopy Performed
["Procedure, Performed": "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
  where Global."NormalizeInterval" ( FlexibleSigmoidoscopy.relevantDatetime, FlexibleSigmoidoscopy.relevantPeriod ) ends during day of Interval[start of "Measurement Period" - 4 years, 
  end of "Measurement Period"]

// removed to simplify 
// Hospice.Has Hospice Services
// exists ( ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
//     where ( InpatientEncounter.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
//         or InpatientEncounter.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
//     )
//       and InpatientEncounter.relevantPeriod ends during day of "Measurement Period"
// )
//   or exists ( ["Encounter, Performed": "Hospice Encounter"] HospiceEncounter
//       where HospiceEncounter.relevantPeriod overlaps "Measurement Period"
//   )
//   or exists ( ["Assessment, Performed": "Hospice care [Minimum Data Set]"] HospiceAssessment
//       where HospiceAssessment.result ~ "Yes (qualifier value)"
//         and Global."NormalizeInterval" ( HospiceAssessment.relevantDatetime, HospiceAssessment.relevantPeriod ) overlaps "Measurement Period"
//   )
//   or exists ( ["Intervention, Order": "Hospice Care Ambulatory"] HospiceOrder
//       where HospiceOrder.authorDatetime during day of "Measurement Period"
//   )
//   or exists ( ["Intervention, Performed": "Hospice Care Ambulatory"] HospicePerformed
//       where Global."NormalizeInterval" ( HospicePerformed.relevantDatetime, HospicePerformed.relevantPeriod ) overlaps "Measurement Period"
//   )
 
Initial Population
AgeInYearsAt(date from 
  end of "Measurement Period"
)in Interval[46, 75]
  // for simplicity remove Qualifying Encounters
  // and exists AdultOutpatientEncounters."Qualifying Encounters"

// moved to cce 
Malignant Neoplasm
["Diagnosis": "Malignant Neoplasm of Colon"] ColorectalCancer
  where ColorectalCancer.prevalencePeriod starts on or before 
  end of "Measurement Period"
 
// numerator is a one-liner and the fiver criteria are found in cce
Numerator
exists "Fecal Occult Blood Test Performed"
  or exists "Fecal Immunochemical Test DNA Performed"
  or exists "Flexible Sigmoidoscopy Performed"
  or exists "CT Colonography Performed"
  or exists "Colonoscopy Performed"
 
// remove for simplicity
// PalliativeCare.Palliative Care in the Measurement Period
// exists ( ["Assessment, Performed": "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"] PalliativeAssessment
//     where Global."NormalizeInterval"(PalliativeAssessment.relevantDatetime, PalliativeAssessment.relevantPeriod) overlaps "Measurement Period"
// )
// or exists (["Diagnosis": "Encounter for palliative care"] PalliativeDiagnosis
// where PalliativeDiagnosis.prevalencePeriod overlaps "Measurement Period")
//   or exists ( ["Encounter, Performed": "Palliative Care Encounter"] PalliativeEncounter
//       where PalliativeEncounter.relevantPeriod overlaps "Measurement Period"
//   )
//   or exists ( ["Intervention, Performed": "Palliative Care Intervention"] PalliativeIntervention
//       where Global."NormalizeInterval"(PalliativeIntervention.relevantDatetime, PalliativeIntervention.relevantPeriod) overlaps "Measurement Period"
//   )

// simplify 
// SDE Ethnicity
// ["Patient Characteristic Ethnicity": "Ethnicity"]
 
// SDE Payer
// ["Patient Characteristic Payer": "Payer"]
 
// SDE Race
// ["Patient Characteristic Race": "Race"]
 
// SDE Sex
// ["Patient Characteristic Sex": "ONC Administrative Sex"]
 
// Stratification 1
// AgeInYearsAt(date from 
//   end of "Measurement Period"
// )in Interval[46, 49]
 
// Stratification 2
// AgeInYearsAt(date from 
//   end of "Measurement Period"
// )in Interval[50, 75]
 
// moved to cce
Total Colectomy Performed
["Procedure, Performed": "Total Colectomy"] Colectomy
  where Global."NormalizeInterval" ( Colectomy.relevantDatetime, Colectomy.relevantPeriod ) ends on or before 
  end of "Measurement Period"

 
Functions
Global.HasEnd(period Interval<DateTime>)
not ( 
  end of period is null
    or 
    end of period = maximum DateTime
)
 
Global.Latest(period Interval<DateTime>)
if ( HasEnd(period)) then 
end of period 
  else start of period
 
Global.LatestOf(pointInTime DateTime, period Interval<DateTime>)
Latest(NormalizeInterval(pointInTime, period))
 
Global.NormalizeInterval(pointInTime DateTime, period Interval<DateTime>)
if pointInTime is not null then Interval[pointInTime, pointInTime]
  else if period is not null then period 
  else null as Interval<DateTime>
 
