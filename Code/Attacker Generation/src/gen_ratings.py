#!/usr/local/bin/python

'''
    Uses the movielens review database to output a new collection that uses
    the reviewer's ID as the _id and contains a list of reviews ratings that
    the user reviewed.
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
                { "_id" : "$reviewerID", "overall" : { "$push" : "$overall" } } 
            },
            # { "$out" : "ratings" }
        ]

    out = list(db.reviews.aggregate(pipeline))
    print len(out)
