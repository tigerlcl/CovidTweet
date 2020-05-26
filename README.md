# CovidTweet
It's an individual project, supervised by [Professor Alan C.B. Tse](https://www.bschool.cuhk.edu.hk/staff/tse-alan-ching-biu/), Department of Marketing, CUHK Business School. I built an automated Tweet Crawler related to #COVID. Collected data could be used for more applications, i.e., sentiment analysis. For this study, I implemented two sections:
- (Automated) Collection Tweet by Date, implemented by Python
- A Brief Correlation Analysis between tweet's sentiment and stock data, implemented by R 

Tools: Python3.6+ ([Tweepy](http://docs.tweepy.org/en/latest/), Pandas), R Studio(Syuzhet, quanmod)

# Declaration
Sensitive Configurations are erased before git commit. In compliance with Twitter’s Terms & Conditions, we are unable to publicly release the text of the collected tweets. 

# Data Overview
- Datetime Interval: 2020-04-05 : 2020-05-26(Now), 4.13-5.3 is omitted as paused by myself, not a technical issue.
- Total tweets: 120,000+

# Quick Start
## Configuration
It's prepared for running Python only. You can edit `config.yaml` with your text editor. You're supposed to hold a valid Twitter Developer Account and application. Fill the `AUTH` field with your personal information. More about [Twitter Developer](https://developer.twitter.com/en).

## For Python
- Install required packages: Run `pip install -r requirements.txt` in your shell.
- Execute code: `python tweet.py`, some text-based filters are applied to prevent bot-like or re-tweet status.
- (Optional) Automated Python: try [crontab](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/crontab.html) or other task scheduler on your server. `tweet.py` can retrieve current day's history tweets so that avoid duplicated tweets.

## For R
Once you accumulated several days of tweet data (**Your Own Dataset!**), run the `covid-sentiment.r` in R studio. 10 kinds of sentiment will be extracted by relevant package. US(S&P 500) and HK (Hang Seng Index) Stock data are retrieved to perform analysis. After that, you are able to implement a simple correlation analysis. Feel free to visualize the result in your R Studio.

# MISC
Feel free to contact me via GitHub email. Thanks for your reading.
