### Description
# A simple correlation analysis on tweets sentiment ~  stock price data

# Packages
library(syuzhet) # sentiment analysis

# Funtion defination
percentage <- function(x) {
  return (x / sum(x))
}

catch.error = function(x){
  # Create a missing value for y
  y = NA
  # try to catch the error 
  catch_error = tryCatch(tolower(x), error=function(e) e)
  # if not an error
  if (!inherits(catch_error, "error"))
    y = tolower(x)
  return(y)
}

# Copied and modified from 'sentiment.R'
text_filter <- function(xxxxx){
  # Above all, Remove @Reply and #hashtag in tweet, which are not useful for sentiment analysis
  xxxxx = gsub("[@#][[:alpha:]_]+","", xxxxx)
  
  # (Continued) remove all the punctuatio
  xxxxx = gsub("[[:punct:]]", "", xxxxx)
  
  # Then remove numbers, we need only text for analytics
  xxxxx = gsub("[[:digit:]]", "", xxxxx)
  
  # Then remove html links, which are not required for sentiment analysis
  xxxxx = gsub("http\\w+", "", xxxxx)
  
  # Then remove unnecessary spaces (white spaces, tabs etc)
  xxxxx = gsub("[ \t]{2,}", "", xxxxx)
  xxxxx = gsub("^\\s+|\\s+$", "", xxxxx)
  
  # Now make all the words in lower case to get a uniform pattern.
  # First define a function which can handle tolower error handling if arises any, during converting all words to lower case.
  # Now we will transform all the words in lower case using catch.error function we just created above and with sapply function
  xxxxx = sapply(xxxxx, catch.error)
  
  # Also we will remove NAs, if any exists, from xxxxx
  xxxxx = xxxxx[!is.na(xxxxx)]
  
  return(xxxxx)
}

### PART 1: Setup dataframe to save all sentiments
sentiment_category <- c("anger","anticipation","disgust","fear","joy","sadness","surprise","trust","negative","positive")
df <- data.frame(matrix(ncol = length(sentiment_category)+1, nrow = 0))
colnames(df) <- c("date", sentiment_category)

# For LOOP estimates time ~3 min, subject to volume of raw data
covid_files <- list.files("raw_twitter_data/")
for (csv_name in covid_files) {
  
  # match date in csv_name, e.g. "covid-hashtag-2020-04-05.csv" -> 2020-04-05
  m <- regexpr("\\d{4}-\\d{2}-\\d{2}", csv_name)
  covid_date <- as.Date(regmatches(csv_name, m))
  
  # print(csv_name)
  # Load Dataset
  tweets <- read.csv(paste("raw_twitter_data/",csv_name, sep = ""))
  cleaned_tweets <- text_filter(tweets$full_text)
  
  # extract text sentiment
  mySentiment <- get_nrc_sentiment(cleaned_tweets)
  sentimentTotals <- data.frame(colSums(mySentiment))
  
  # convert to percent-style for tweet sampling variance
  sentimentTotals <- percentage(sentimentTotals)
  
  # transpose to row dataframe then combined with empty full dataframe
  row_df <- data.table::transpose(sentimentTotals)
  
  # set row and column name
  names(row_df) <- rownames(sentimentTotals)
  row_df$date = covid_date
  
  # row_df combine to df
  df <- rbind(df, row_df)
  
} # Time cost subjects to volume of dataset

# Save Tweet Sentiment Result
# write.csv(df, "covid_sentiment.csv", row.names = FALSE)

### PART 2: Tweet Sentiment ~ Stock Price Correlation Analysis
library(quantmod) # financial modeling

# Set Date Interval, format: "YYYY-MM-DD" (zero-padding required)
tweet_start_date = "2020-04-05"
tweet_end_date = "2020-05-15"

## S&P500
loadSymbols("^GSPC", src = "yahoo",  from = tweet_start_date, to = tweet_end_date)
gspc <- data.frame(date=index(GSPC), coredata(GSPC))

# Merge two dataframes by date
gspc_covid <- merge(df, gspc)

# Correlation Analysis, Pearson Correlation
gspc_res <- data.frame(sapply(gspc_covid[2:11], cor.test, y=gspc_covid$GSPC.Close))
View(gspc_res)

## Conclusions:
# Sentiment 'surprise' is negative correlated with S&P.Close price, with cor = -0.684, p-value = 0.0099 
# Sentiment 'joy' is negative correlated with S&P.Close price, with cor = -0.695, p-value = 0.0083
# Sentiment 'disgust' is negative correlated with S&P.Close price, with cor = -0.513, p-value = 0.0725 (p close to 0.05)


## Hang Seng Index
loadSymbols("^HSI", src = "yahoo",  from = tweet_start_date, to = tweet_end_date)
hsi <- data.frame(data=index(HSI), coredata(HSI))
colnames(hsi)[colnames(hsi) == 'data'] <- 'date'

# Merge two dataframes by date
hsi_covid <- merge(df, hsi, by = "date")

# Correlation analysis, Pearson Correlation
hsi_res <- data.frame(sapply(hsi_covid[2:11], cor.test, y = hsi_covid$HSI.Close))
View(hsi_res)

## Conclusions:
# Sentiment 'positive' is positive correlated with HSI.Close price, with cor = 0.558, p-value = 0.0473
# Sentiment 'sadness' is negative correlated with HSI.Close price, with cor = -0.496, p-value = 0.0844 (p close to 0.05)


