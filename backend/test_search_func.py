from database.product_search import search_products
from database.product_fetch import fetch_products_by_status

def run_tests():
    # Test searches
    queries = ["cream", "night cream", "BL MIRA", "nonexistent"]
    for q in queries:
        res = search_products(q)
        print(f"Query: '{q}' -> Found {len(res)} results")
        if res:
            print(f"  First: {res[0]['product']} ({res[0]['company']})")

    # Test status fetch
    statuses = ["Notified", "Cancelled"]
    for status in statuses:
        res = fetch_products_by_status(status, limit=5, offset=0)
        print(f"Status: '{status}' -> Found {len(res)} results")
        if res:
            for item in res:
                print(f"  - {item['product']} [{item['status']}]")

if __name__ == "__main__":
    run_tests()
