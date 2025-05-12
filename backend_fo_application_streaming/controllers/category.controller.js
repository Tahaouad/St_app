const { Category, Genre } = require('../models');

// Get all categories
const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.findAll({
      where: { isActive: true },
      order: [['displayOrder', 'ASC'], ['name', 'ASC']]
    });
    
    res.status(200).json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ message: "Error fetching categories", error: error.message });
  }
};

// Get all genres
const getAllGenres = async (req, res) => {
  try {
    const genres = await Genre.findAll({
      order: [['name', 'ASC']]
    });
    
    res.status(200).json(genres);
  } catch (error) {
    console.error('Error fetching genres:', error);
    res.status(500).json({ message: "Error fetching genres", error: error.message });
  }
};

module.exports = {
  getAllCategories,
  getAllGenres
};