import type { CloudEventFunction } from "@google-cloud/functions-framework";
import type { StorageObjectData } from "@google/events/cloud/storage/v1/StorageObjectData";

export const fileInfo: CloudEventFunction<StorageObjectData> = (event) => {
  console.log("Event ID:", event.id);
  console.log("Event type:", event.type);
  console.log("Bucket:", event.data?.bucket);
  console.log("File:", event.data?.name);
  console.log("Metageneration:", event.data?.metageneration);
  console.log("Created:", event.data?.timeCreated);
  console.log("Updated:", event.data?.updated);
  console.log("---------- UPDATE ----------");
  return;
};
