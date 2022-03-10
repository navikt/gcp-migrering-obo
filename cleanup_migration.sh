#!/bin/bash
kubectl delete pod gcloud
kubectl delete pvc pvc-dumpdisk
kubectl delete secret migration-user
