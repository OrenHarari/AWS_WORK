from transformers import AutoModelForCausalLM, AutoTokenizer
import torch


class CodeCompleter:
    def __init__(self):
        print("Initializing Mistral for code completion...")
        self.tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
        self.model = AutoModelForCausalLM.from_pretrained(
            "mistralai/Mistral-7B-v0.1",
            torch_dtype=torch.float16,
            device_map="auto"
        )

    def complete_code(self, code_context):
        """
        Takes incomplete code and suggests completion
        Example: If you type 'def calculate_average(numbers):'
        It will suggest the function body
        """
        prompt = f"""Complete this code:
{code_context}
"""
        # Tokenize the input
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)

        # Generate completion
        outputs = self.model.generate(
            **inputs,
            max_length=150,
            num_return_sequences=1,
            temperature=0.2,  # Lower temperature for more focused completions
            do_sample=True
        )

        completion = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        # Remove the original prompt from the completion
        completion = completion.replace(prompt, "").strip()
        return completion


def main():
    completer = CodeCompleter()

    # Example 1: Complete a function definition
    incomplete_code = """def calculate_average(numbers):
    """

    print("Example 1: Completing a function definition")
    print("Input:")
    print(incomplete_code)
    print("\nSuggested completion:")
    print(completer.complete_code(incomplete_code))

    # Example 2: Complete a for loop
    incomplete_code = """for i in range(10):
    """

    print("\nExample 2: Completing a for loop")
    print("Input:")
    print(incomplete_code)
    print("\nSuggested completion:")
    print(completer.complete_code(incomplete_code))


if __name__ == "__main__":
    main()