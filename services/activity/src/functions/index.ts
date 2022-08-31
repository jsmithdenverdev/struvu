import * as functions from "@google-cloud/functions-framework";
import type { StorageObjectData } from "@google/events/cloud/storage/v1/StorageObjectData";
import { fileInfo } from "./file-info";

functions.cloudEvent<StorageObjectData>("fileInfo", fileInfo);
