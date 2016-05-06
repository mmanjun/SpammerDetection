#!/usr/local/bin/python

'''
    Generates the 6 types of shilling attackers.
'''

from pymongo import MongoClient
import random
import json

def generate_random_attackers(db, num, startId):
    ids = map(int, db.movies.distinct("_id"))
    ids.sort()

    rvals = random.sample(ids, num + 1)

    rreviews = []
    for i in range(num):
        rreviews.append(random.randint(1, 5))
    
    output = { 
                "reviewerID" : "100", 
                "asin" : str(rvals[0]),
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    for i in range(len(rvals) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(rvals[i])
        output["overall"] = rreviews[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(rvals[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

def generate_random_attackers2(db, num, popAsins, startId):
    ids = map(int, db.movies.distinct("_id"))
    ids.sort()

    popAsins = map(int, popAsins)
    ids = set(ids) - set(popAsins)
    ids = list(ids)

    rvals = random.sample(ids, num + 1)

    rreviews = []
    for i in range(num):
        rreviews.append(random.randint(1, 5))
    
    output = { 
                "reviewerID" : "100", 
                "asin" : str(rvals[0]),
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    for i in range(len(rvals) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(rvals[i])
        output["overall"] = rreviews[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(rvals[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

def generate_average_attackers(db, num, startId):
    ids = map(int, db.movies.distinct("_id"))
    ids.sort()

    rvals = random.sample(ids, num + 1)

    output = { 
                "reviewerID" : "100", 
                "asin" : str(rvals[0]),
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    avg_ratings = []
    for i in range(len(rvals)):
        out = db.movies.find_one( { "_id" : str(rvals[i]) }, {"_id":0 } )
        rating = out["overall"]
        avg_ratings.append(sum(rating)/len(rating))

    for i in range(len(rvals) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(rvals[i])
        output["overall"] = avg_ratings[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(rvals[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

def generate_average_attackers2(db, num, popAsins, startId):
    ids = map(int, db.movies.distinct("_id"))
    ids.sort()

    popAsins = map(int, popAsins)
    ids = set(ids) - set(popAsins)
    ids = list(ids)

    rvals = random.sample(ids, num + 1)

    output = { 
                "reviewerID" : "100", 
                "asin" : str(rvals[0]),
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    avg_ratings = []
    for i in range(len(rvals)):
        out = db.movies.find_one( { "_id" : str(rvals[i]) }, {"_id":0 } )
        rating = out["overall"]
        avg_ratings.append(sum(rating)/len(rating))

    for i in range(len(rvals) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(rvals[i])
        output["overall"] = avg_ratings[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(rvals[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

def generate_random_popular(db, num, startId):
    #ids = map(int, db.movies.distinct("_id"))
    #ids.sort()

    pipeline = [
            { "$project" :
                { "numRatings" : { "$size" : "$overall" } }
            },
            { "$out" : "rating_num" }
        ]

    db.movies.aggregate(pipeline)

    count = db.rating_num.count()

    five_percent = int(0.05 * count)

    out = list(db.rating_num.find().sort("numRatings", -1))

    ids = []
    for i in range(num + 1):
        ids.append(out[i]["_id"])

    rreviews = []
    for i in range(num):
        rreviews.append(random.randint(1, 5))

    output = { 
                "reviewerID" : "100", 
                "asin" : "0",
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    for i in range(len(ids) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(ids[i])
        output["overall"] = rreviews[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(ids[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

    db.rating_num.drop()
    #print "Random-Over-Popular"

    return ids

def generate_average_popular(db, num, startId):
    pipeline = [
            { "$project" :
                { "numRatings" : { "$size" : "$overall" } }
            },
            { "$out" : "rating_num" }
        ]

    db.movies.aggregate(pipeline)

    count = db.rating_num.count()

    five_percent = int(0.05 * count)

    out = list(db.rating_num.find().sort("numRatings", -1))

    ids = []
    for i in range(num + 1):
        ids.append(out[i]["_id"])

    avg_ratings = []
    for i in range(num):
        out = db.movies.find_one( { "_id" : str(ids[i]) }, {"_id":0 } )
        rating = out["overall"]
        avg_ratings.append(sum(rating)/len(rating))

    output = { 
                "reviewerID" : "100", 
                "asin" : "0",
                "overall" : 2,
                "reviewTime" : "880606923"
             }

    for i in range(len(ids) - 1):
        output["reviewerID"] = startId
        output["asin"] = str(ids[i])
        output["overall"] = avg_ratings[i]
        print json.dumps(output, indent=4)

    # generating the target
    output["reviewerID"] = startId
    output["asin"] = str(ids[i+1])
    output["overall"] = 4 # max - 1
    print json.dumps(output, indent=4)

    db.rating_num.drop()
    #print "Average-Over-Popular"

    return ids

def generate_random_bandwagon(db, num, startId):
    #generate_random_attackers(db, num/2)
    popAsins = generate_random_popular(db, num/2, startId)
    generate_random_attackers2(db, num/2, popAsins, startId)
    #print "Random Bandwagon"

def generate_average_bandwagon(db, num, startId):
    #generate_average_attackers(db, num/2)
    popAsins = generate_average_popular(db, num/2, startId)
    generate_average_attackers2(db, num/2, popAsins, startId)
    #print "Average Bandwangon"

if __name__ == "__main__":
    client = MongoClient()

    db = client['movielens']
    movies = db['movies']

    #print "Entries: %d" % movies.count()

    random.seed(123456789)

    num_movies = movies.count()

    five_percent = int(0.05 * num_movies)
    ten_percent = int(0.1 * num_movies)
    fifteen_percent = int(0.15 * num_movies)
    twenty_percent = int(0.2 * num_movies)

    for i in range(17):
        #generate_random_attackers(db, ten_percent, 2000 + i)
        #generate_average_attackers(db, ten_percent, 2000 + i)
        #generate_random_popular(db, ten_percent, 2000 + i)
        #generate_average_popular(db, ten_percent, 2000 + i)
        #generate_random_bandwagon(db, ten_percent, 2000 + i)
        generate_average_bandwagon(db, ten_percent, 2000 + i)
