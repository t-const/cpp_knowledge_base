#include <gtest/gtest.h>

// Example test case
TEST(SampleTest, Test1)
{
  std::cout << "This is a test" << std::endl;
  EXPECT_EQ(1 + 1, 2);
}

TEST(SampleTest, Test2)
{
  std::cout << "This is another test" << std::endl;
  EXPECT_EQ(1 + 1, 2);
}