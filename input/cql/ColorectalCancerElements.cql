library ColorectalCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include ColorectalCancerConcepts called Cx

parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 1 year, Now()]

context Patient

define AsOf:
  end of "Measurement Period"

define function MostRecent(procedures List<Procedure>, asOf DateTime):
  First(
    procedures P
      sort by start of FC.ToInterval(performed)
  )

define function MostRecent(observations List<Observation>):
  First(
    observations O
      sort by issued
  )

define function IssuedWithin(observations List<Observation>, lookback System.Quantity):
  observations O
    where O.issued on or after day of AsOf - lookback

define function PerformedWithin(procedures List<Procedure>, lookback System.Quantity):
  procedures P
    where end of FC.ToInterval(P.performed) on or after day of AsOf - lookback

define "Total Colectomy Performed":
  [Procedure: Cx."Total Colectomy"] Colectomy
    where Colectomy.status = 'completed'

define "Has Total Colectomy Performed":
  exists (
    PerformedWithin("Total Colectomy Performed", 1 year)
  )

define "Total Colectomy from Patient History":
  [Condition: Cx."Total Colectomy"] ColectomyCondition
    where ColectomyCondition.clinicalStatus in FC."Active Condition"
      and ColectomyCondition.verificationStatus ~ FC."confirmed"

define "Has History of Total Colectomy":
 exists (
    "Total Colectomy from Patient History" ColectomyHistory
      where FC.ToPrevalenceInterval(ColectomyHistory) starts on or before AsOf
  )

define "Active Malignant Neoplasm":
  [Condition: Cx."Malignant Neoplasm of Colon"] ColorectalCancer
    where ColorectalCancer.clinicalStatus in FC."Active Condition"
      and ColorectalCancer.verificationStatus ~ FC."confirmed"

define "Has Active Malignant Neoplasm":
  exists (
    "Active Malignant Neoplasm" M
      where FC.ToPrevalenceInterval(M) starts on or before AsOf
  )

define "Fecal Occult Blood Test Result":
  [Observation: Cx."Fecal Occult Blood Test (FOBT)"] FecalOccultResult
		where FecalOccultResult.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FecalOccultResult.value is not null

define "Most Recent Fecal Occult Blood Test Result":
  MostRecent("Fecal Occult Blood Test Result")

define "Fecal Occult Blood Test Result Within 1 Year":
  "Fecal Occult Blood Test Result" R
    where R.issued 1 year or less on or before AsOf

define "Fecal Immunochemical Test DNA Result":
  [Observation: Cx."FIT DNA"] FitDNA
		where FitDNA.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FitDNA.value is not null

define "Most Recent Fecal Immunochemical Test DNA Result":
  MostRecent("Fecal Immunochemical Test DNA Result")

define "Fecal Immunochemical Test DNA Result Within 3 Years":
  "Fecal Immunochemical Test DNA Result" R
    where R.issued 3 years or less on or before AsOf

define "CT Colonography Performed":
  [Procedure: Cx."CT Colonography"] Colonography
    where Colonography.status = 'completed'

define "Most Recent CT Colonography Performed":
  MostRecent("CT Colonography Performed", AsOf)

define "CT Colonography Performed Within 5 Years":
  "CT Colonography Performed" P
    where FC.ToInterval(P.performed) ends 5 years or less on or before AsOf

define "Flexible Sigmoidoscopy Performed":
  [Procedure: Cx."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'

define "Most Recent Flexible Sigmoidoscopy Performed":
  MostRecent("Flexible Sigmoidoscopy Performed", AsOf)

define "Flexible Sigmoidoscopy Performed Within 5 Years":
  "Flexible Sigmoidoscopy Performed" P
    where FC.ToInterval(P.performed) ends 5 years or less on or before AsOf

define "Colonoscopy Performed":
  [Procedure: Cx."Colonoscopy"] Colonoscopy
		where Colonoscopy.status = 'completed'

define "Most Recent Colonoscopy Performed":
  MostRecent("Colonoscopy Performed", AsOf)

define "Colonoscopy Performed Within 10 Years":
  "Colonoscopy Performed" P
    where FC.ToInterval(P.performed) ends 10 years or less on or before AsOf

define "Has Appropriate Colorectal Cancer Screening":
  exists "Fecal Occult Blood Test Result Within 1 Year"
    or exists "Fecal Immunochemical Test DNA Result Within 3 Years"
    or exists "CT Colonography Performed Within 5 Years"
    or exists "Flexible Sigmoidoscopy Performed Within 5 Years"
    or exists "Colonoscopy Performed Within 10 Years"

define "Flexible Sigmoidoscopy from Patient History":
  [Condition: Cx."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopyCondition
    where FlexibleSigmoidoscopyCondition.clinicalStatus in FC."Active Condition"
      and FlexibleSigmoidoscopyCondition.verificationStatus ~ FC."confirmed"

define "Colonoscopy from Patient History":
  [Condition: Cx."Colonoscopy"] C
    where C.clinicalStatus in FC."Active Condition"
    and C.verificationStatus ~ FC."confirmed"

define "Has History of Appropriate Colorectal Cancer Screening":
  exists (
    "Flexible Sigmoidoscopy from Patient History" FlexSigCondition
      where FC.ToPrevalenceInterval(FlexSigCondition) starts on or after day of AsOf - 5 years)
  or exists (
    "Colonoscopy from Patient History" ColonscopyCondition
      where FC.ToPrevalenceInterval(ColonscopyCondition) starts on or after day of AsOf - 10 years)

