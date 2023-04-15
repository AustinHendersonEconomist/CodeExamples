library(MTurkR)
Sys.setenv(AWS_ACCESS_KEY_ID = "accesskey")
Sys.setenv(AWS_SECRET_ACCESS_KEY = "secretaccesskey")

qual3 <-
  CreateQualificationType(
    name="Qualification to Prevent Retakes of social norms survey",
    description="This qualification is for people who have worked for me on this task before.",
    status = "Active",
    keywords= "Worked for me before",
    auto = FALSE)

w <- c('AWNQdE62XRB0O',
       'A20SI2dSAHUXP4',
       'A3N0QZ9ZKUdTCQ',
       'AQKTLQV04dD4N'
) # a vector containing WorkerIds

AssignQualification(
  qual = qual3$QualificationTypeId,
  workers = w,
  value = "50"
)