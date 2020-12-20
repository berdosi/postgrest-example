-- api schema will be accessible by the API

CREATE SCHEMA "api";

-- API: get an order form (to render, to place a new one)
CREATE VIEW "api"."order_form" AS
    SELECT
        "s"."id"            AS "id",
        "s"."display_name"  AS "display_name",
        "s"."size"          AS "size",
        "st"."amount" > 0   AS "in_stock",
        "p"."price"         AS "price"
    FROM
        "master_data"."sku" "s"
    JOIN "master_data"."price" "p"
        ON "s"."id" = "p"."sku_id"
    JOIN "master_data"."stock" "st"
        on "s"."id" = "st"."sku_id";

-- list own orders, with statuses
CREATE VIEW "api"."list_orders" AS
    SELECT * FROM "master_data"."order"
    WHERE "user_id" = current_setting('request.jwt.claim.user_id', true)::INTEGER;

-- send / update an order
CREATE FUNCTION "api"."order"(param json) RETURNS VOID AS $SQL$
	DECLARE
        "order_id_new" INTEGER;
        "order_line_raw" JSON;
        "current_user_id" INTEGER := current_setting('request.jwt.claim.user_id', true)::INTEGER;
    BEGIN
        IF "current_user_id" IS NULL THEN
            RAISE EXCEPTION 'NOT LOGGED IN';
        END IF;
        
        INSERT INTO "master_data"."order" ("user_id") VALUES 
            ("current_user_id")
            RETURNING "id"
            INTO "order_id_new";
        FOREACH "order_line_raw" IN ARRAY array(SELECT json_array_elements(param)) LOOP
            INSERT INTO "master_data"."order_line" ("order_id", "sku_id", "amount")
            VALUES (
                "order_id_new",
                ("order_line_raw"->'sku_id')::TEXT::INTEGER,
                ("order_line_raw"->'amount')::TEXT::INTEGER);
        END LOOP;
    END;
$SQL$ LANGUAGE PLPGSQL SECURITY DEFINER;



--- grants
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT EXECUTE ON FUNCTION "api"."order" TO web_anon;
GRANT SELECT ON "api"."list_orders" TO web_anon;
GRANT SELECT ON "api"."order_form" TO web_anon;


