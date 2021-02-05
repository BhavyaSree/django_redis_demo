from django.shortcuts import render

# Create your views here.
import json
from django.conf import settings
import redis
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response

# Connect to our Redis instance
redis_instance = redis.StrictRedis(host=settings.REDIS_HOST,
                                  port=settings.REDIS_PORT, db=0, password=settings.REDIS_PASSWORD)

@api_view(['GET'])
def send_number(request, *args, **kwargs):
    if request.method == 'GET':
        key = "num123"

        val = redis_instance.hget(key, "count")
        if val is None:
            redis_instance.hset(key, "count", 0)
            val = redis_instance.hget(key, "count")
        val = int(val)
        redis_instance.hincrby(key, "count", 1)

        response = {
            'count': val,
        }
        return Response(response, status=200)

