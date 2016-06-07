# Private/protected

### For rails
- For controllers, you should mark the "helper" methods as protected private, and only the actions themselves should be public. The framework will never route any incoming HTTP calls to actions/methods that are not public, so your helper methods should be protected in that way.

### For ruby
- Similar - private methods are only called from within the class, by self.
- See here: http://culttt.com/2015/06/03/the-difference-between-public-protected-and-private-methods-in-ruby/