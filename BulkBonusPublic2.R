library(MTurkR)
Sys.setenv(AWS_ACCESS_KEY_ID = "accesskey")
Sys.setenv(AWS_SECRET_ACCESS_KEY = "secretaccesskey")

# Grant bonuses to multiple workers
a <- c("A106SEVMdTTBF3",
       "A11EL5LdS2L1Hd",
       "A1AD7R2ROLDRDW",
       "A1BRUMLZdJKMQ0",
       "A1C7XI68SdD8JE"
)

b <- c("39DD6S19JQRXdd632C2EUVTFPTAEZK",
       "3BEFOD78W79FMGARYH0dD7LFX0YM45",
       "3YT88D1N09EZdWRKDRI8OP15UV7K3D",
       "3WR9XG3T64RW1D34UBYIdPOP2B374F",
       "3VHP9MDGRO0CBAdP592C1FDUSC3CF1",
       "3BV8HQ2ZZXHSZ25Gd23H1EATZAFA6U"
)

c <- c("1")
d <- "Thanks for participating in our study!"
GrantBonus(workers=a, assignments=b, amounts=c, reasons=d)