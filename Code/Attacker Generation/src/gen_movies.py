#!/usr/local/bin/python

'''
    Uses the movielens review database to output a new collection that uses
    the movie asin as the _id and contains a list of reviews for each asin.
'''

from pymongo import MongoClient

if __name__ == "__main__":

    db_name = "movielens"
    coll_name = "reviews"

    client = MongoClient()

    db = client[db_name]
    reviews = db[coll_name]

    pipeline = [
            { "$group" : 
                { "_id" : "$asin", "overall" : { "$push" : "$overall" } } 
            },
            # { "$out" : "movies" }
        ]

    out = list(db.reviews.aggregate(pipeline))
    print len(out)
