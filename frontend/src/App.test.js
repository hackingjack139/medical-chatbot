import { render, screen } from "@testing-library/react";
import App from "./App";

beforeEach(() => {
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve(["itching", "headache"]),
    })
  );
});

afterEach(() => {
  jest.resetAllMocks();
});

test("renders medical chatbot heading", async () => {
  render(<App />);

  expect(screen.getByText(/medical chatbot/i)).toBeInTheDocument();
  expect(
    await screen.findByText(/select or type symptoms/i)
  ).toBeInTheDocument();
});
