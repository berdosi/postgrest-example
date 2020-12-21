-- Create master_data schema.

-- master_data schema contains the raw data : list of SKU, their stock / price changes
-- This is not exposed to the API.

CREATE SCHEMA "master_data";

CREATE TYPE "master_data"."sku_kind" AS ENUM ('strong', 'weak', 'merch');

CREATE TABLE "master_data"."sku" (
    "id" SERIAL PRIMARY KEY,
    "display_name" VARCHAR NOT NULL,
    "size" VARCHAR, -- e.g. 0.7L
    "kind" "master_data"."sku_kind" NOT NULL
);

CREATE TABLE "master_data"."price_change" (
    "id" SERIAL PRIMARY KEY,
    "sku_id" INTEGER NOT NULL REFERENCES "master_data"."sku"("id"),
    "price" NUMERIC NOT NULL,
    "timestamp" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "master_data"."user" (
    "id" SERIAL PRIMARY KEY,
    "email" VARCHAR,
    "password_hash" VARCHAR
);

CREATE TYPE "master_data"."order_status" AS ENUM (
    'draft',    -- draft orders are the ones the user is still working on
    'sent',     -- sent for the store for approval
    'approved', -- store approved, user can pay (sending is not possible when
                -- something gets out of stock meanwhile)
    'paid',     -- store received the payment
    'delivered' -- order was sent for delivery
);

CREATE TABLE "master_data"."order" (
    "id" SERIAL PRIMARY KEY,
    "user_id" INTEGER REFERENCES "master_data"."user"("id") NOT NULL,
    "status" "master_data"."order_status" DEFAULT 'draft'::"master_data"."order_status" NOT NULL,
    "timestamp" timestamptz DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "master_data"."order_line" (
    "order_id" INTEGER REFERENCES "master_data"."order"("id") NOT NULL,
    "sku_id" INTEGER REFERENCES "master_data"."sku"("id") NOT NULL,
    "amount" INTEGER NOT NULL,
    PRIMARY KEY ("order_id", "sku_id")
);

CREATE TABLE "master_data"."buy" (
    "id" SERIAL PRIMARY KEY,
    "timestamp" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "master_data"."buy_line" (
    "id" SERIAL PRIMARY KEY,
    "sku_id" INTEGER REFERENCES "master_data"."sku"("id") NOT NULL,
    "amount" INTEGER NOT NULL
);

-- master_data: helper views

CREATE VIEW "master_data"."price" AS
    SELECT DISTINCT ON (sku_id)
        "sku_id",
        "price"
    FROM
        master_data.price_change
    ORDER BY
        sku_id,
        id DESC;

CREATE VIEW "master_data"."stock" AS
    SELECT
        "sku_id"        AS "sku_id",
        SUM("amount")   AS "amount"

    FROM (
            SELECT
                "sku_id",
                -"amount" "amount"
            FROM
                "master_data"."order_line" "ol"
            JOIN "master_data"."order" "o"
                ON "ol"."order_id" = "o"."id"
            WHERE
                "o"."status" IN ('approved', 'paid', 'delivered')
        UNION
            SELECT
                "sku_id",
                "amount"
            FROM
                "master_data"."buy_line"
    ) "s"
    GROUP BY "sku_id";

-----------------------------------------------------------------
CREATE TABLE "master_data"."configuration" (
    "db_version" INTEGER,
);
