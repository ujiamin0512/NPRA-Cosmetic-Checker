import sys
import os
from chat_bot import chat_bot

def test_bot():
    print("--- Testing ChatBotManager ---")
    
    # 1. Test initial analysis
    print("\n[Test 1] Testing generate_initial_analysis...")
    context = {
        "product_name": "Test Serum",
        "ingredients": "Water, Glycerin, Niacinamide",
        "skin_profile": "Oily, Acne-prone"
    }
    try:
        reply = chat_bot.generate_initial_analysis(context)
        print("Success! Reply received:")
        print("-" * 30)
        print(reply.encode('ascii', 'ignore').decode('ascii'))
        print("-" * 30)
    except Exception as e:
        print(f"Failed Test 1: {e}")

    # 2. Test normal message
    print("\n[Test 2] Testing process_message (General question)...")
    history = [
        {"role": "user", "content": "What is niacinamide?"},
        {"role": "assistant", "content": "Niacinamide is Vitamin B3..."}
    ]
    try:
        result = chat_bot.process_message(
            flow_type="product",
            history=history,
            new_message="Is it good for oily skin?",
            context=context
        )
        print("Success! Reply received:")
        print("-" * 30)
        print(result['reply'])
        print("-" * 30)
    except Exception as e:
        print(f"Failed Test 2: {e}")

if __name__ == "__main__":
    test_bot()
