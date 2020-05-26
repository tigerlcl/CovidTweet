#!/usr/bin/python
# -*- coding: UTF-8 -*-
# Author: Tiger Li

import os
import yaml
import pandas as pd
from datetime import date, datetime, timezone
from easydict import EasyDict as edict
from tweepy import API, AppAuthHandler

class TweeCovid(API):
	"""
	A Customized Tweet Crawler Class designed for #COVID19
	Inherited from tweepy API Class
	"""

	def __init__(self,cfg):
		
		# OAuth-Application
		auth = AppAuthHandler(**cfg.AUTH)
		super().__init__(auth, **cfg.WAIT_RATE)

		self.search_settings = cfg.SEARCH
		self.tweet_attr = cfg.TWEET_ATTR
		self.user_attr = cfg.USER_ATTR
		self.order = cfg.DF_COL_ORDER
		self.drop = cfg.DROP_ARGS
		self.today = date.today().strftime("%Y-%m-%d")

		#self.demo_user = "xxx"

		self.csv_name = cfg.ENV.CSV_PREFIX + self.today + cfg.ENV.CSV_POSTFIX
		self.csv_path = os.path.join(HOME_DIR, cfg.ENV.OUTPUT_DIR, self.csv_name)
		self.tweets = ""

		if not os.path.isdir(cfg.ENV.OUTPUT_DIR):
			os.makedirs(cfg.ENV.OUTPUT_DIR)
		
		self.set_since_id()

	def set_since_id(self):
		# update search since_id based on last search 
		if os.path.exists(self.csv_path):
			last_df = pd.read_csv(self.csv_path)

			self.search_settings.since_id = last_df.loc[0,'id']+1
			#print(self.search_settings.since_id)
			self.last_df = last_df


	def user_demo(self):
		"""
		retrieve the first tweet of demo user
		"""
		tweets = self.user_timeline(id=self.demo_user)
		print(tweets[-1])

	def search_covid(self):
		self.tweets = self.search(**self.search_settings)

	def tweet_filter(self):
		"""filter out these useful attributes"""

		tweet_data = []
		for tweet in self.tweets:
			if getattr(tweet, "retweet_count") > 0:
				continue
			
			tweet_info = {key:getattr(tweet, key) for key in self.tweet_attr}
			# datetime convention
			local_dt = tweet_info['created_at'].replace(tzinfo=timezone.utc).astimezone(tz=None)
			tweet_info['created_at'] = local_dt.strftime("%m/%d/%Y, %H:%M:%S") # time format

			user_obj = tweet_info.pop('user', None)
			if user_obj: # Not empty
				user_info = {key:getattr(user_obj, key) for key in self.user_attr}
				# update id -> user_id
				user_info['user_id'] = user_info.pop('id')
				# append user info into tweet information
				tweet_info.update(user_info)

			tweet_data.append(tweet_info)

		if len(tweet_data)> 0:
			return tweet_data
		else:
			return None

	def save_data(self, data):
		df = pd.DataFrame(data)
		# re-arrange
		df = df[self.order]
		
		if os.path.exists(self.csv_path): 
			# remove duplicated before it appends
			df = df.append(self.last_df, ignore_index=True)
			#print("executed!")
			#df.drop_duplicates(**self.drop)

		df.to_csv(self.csv_path, index=False) # create

if __name__ == '__main__':

	HOME_DIR = os.getcwd()

	with open("config.yaml") as f:
		config = edict(yaml.load(f, Loader=yaml.FullLoader))

	tool = TweeCovid(config) # make object instance
	tool.search_covid() # search relevant tweets
	covid_data = tool.tweet_filter() #extract userful information

	if covid_data:
		#pdb.set_trace()
		tool.save_data(covid_data)
	else: 
		exit()


	
