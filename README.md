# r-dwca-writer

## Installation

```r
remotes::install_github("pieterprovoost/r-dwca-writer")
```

## Example usage

```r
library(dwcawriter)

occurrence <- data.frame(
  "occurrenceID" = c(1, 2, 3),
  "scientificName" = c("Abra alba", "Lanice conchilega", "Nereis diversicolor"),
  "notes" = c("white", "brown", "green"),
  "year" = c(2008, 2009, 2010),
  "basisOfRecord" = c("HumanObservation", "HumanObservation", "HumanObservation")
)

mof <- data.frame(
  "id" = c(1, 2, 3),
  "measurementType" = c("temperature", "temperature", "temperature"),
  "measurementValue" = c(12, 13, 14)
)

archive <- list(
  eml = '<eml:eml packageId="https://obis.org/dummydataset/v1.0" scope="system" system="http://gbif.org" xml:lang="en" xmlns:dc="http://purl.org/dc/terms/" xmlns:eml="eml://ecoinformatics.org/eml-2.1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="eml://ecoinformatics.org/eml-2.1.1 http://rs.gbif.org/schema/eml-gbif-profile/1.2/eml.xsd">
      <dataset>
      <title xml:lang="en">Dummy Dataset</title>
      </dataset>
    </eml:eml>',
  core = list(
    name = "occurrence",
    type = "https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml",
    index = 1,
    data = occurrence
  ),
  extensions = list(
    list(
      name = "measurementorfact",
      type = "https://rs.gbif.org/extension/dwc/measurements_or_facts_2022-02-02.xml",
      index = 1,
      data = mof
    )
  )
)

write_dwca(archive, "test.zip")
```
